#!/usr/bin/env python

#  CHECKOUT TO DART!!!
#  ./pox.py forwarding.l2_multi openflow.discovery --eat-early-packets openflow.spanning_tree --no-flood --hold-down
#  sudo python3 dragonfly-connet.py

from mininet.net import Containernet
from mininet.node import Controller, RemoteController, Docker
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import Link, Intf, TCLink
from mininet.topo import Topo
from mininet.util import dumpNodeConnections
import logging
import os
from random import randint


logging.basicConfig(filename='./dragonfly.log', level=logging.DEBUG)
logger = logging.getLogger(__name__)


class DragonFly(Topo):
    logger.debug("Class DragonFly")
 
    def __init__(self, g, a, p, h):
        """
        g - number of groups
        a - number of switches in group
        p - number of hosts for each switches
        h - number inter-links of each switches
        """
        self.g_num = g
        self.s_g_num = a
        self.h_s_num = p
        self.s_interlinks_num = h
        logger.debug(f"Start with g={g}, a={a}, p={p}, h={h}")

        self.loss_prob = int(os.getenv('PACKET_LOSS', default=0))

        #Init Topo
        Topo.__init__(self)

    def createTopo(self, bw_sw_h=0.2, bw_inn_sw=0.5, bw_int_sw=0.7):
        "Create DragonFly topo."

        groups_switches = self.createGroupsSwitches()
        logger.debug("Finished groups of switches creation!")

        hosts = self.createHosts()
        logger.debug("Finished hosts creation!")

        switchhostlink_opts = dict(bw=bw_sw_h)
        self.addSwitchHostLinks(groups_switches, hosts, switchhostlink_opts)
        logger.debug("Finished adding switch-host links!")

        innerlink_opts = dict(bw=bw_inn_sw)
        self.addInnerGroupsLinks(groups_switches, innerlink_opts)
        logger.debug("Finished adding inner group links!")

        interlink_opts = dict(bw=bw_int_sw)
        self.addInterLinks(groups_switches, interlink_opts)
        logger.debug("Finished adding inter-links of switches!")


    """
    Create Switches and Hosts
    """
    def createGroupsSwitches(self):
        return [[self.addSwitch(f"s{num_group}00{num_switch}")
                for num_switch in range(1, self.s_g_num + 1)] 
            for num_group in range(1, self.g_num + 1)]


    def createHosts(self):
        image="spagnuolocarmine/docker-mpi"
        return [self.addHost(f"h00{num_host}", cls=Docker, dimage=image, volumes=["data:/data"]) 
            for num_host in range(1, self.g_num * self.s_g_num * self.h_s_num + 1)]


    """
    Add Links
    """
    def addInnerGroupsLinks(self, groups_switches, linkopts):
        for group_switches in groups_switches:
            for i in range(self.s_g_num):
                for j in range(i + 1, self.s_g_num):
                    self.addLink(
                        group_switches[i], 
                        group_switches[j],
                        loss=10 if (int(randint(0, 100)) < self.loss_prob) else 0,
                        **linkopts)


    def addSwitchHostLinks(self, groups_switches, hosts, linkopts):
        for num_group in range(self.g_num):
            for num_switch in range(self.s_g_num):
                for i in range(self.h_s_num):
                    self.addLink(
                        groups_switches[num_group][num_switch], 
                        hosts[num_group*self.s_g_num*self.h_s_num + num_switch*self.h_s_num+i],
                        loss=10 if (int(randint(0, 100)) < self.loss_prob) else 0,
                        **linkopts)


    def addInterLinks(self, groups_switches, linkopts):
        number_inter_links = [[self.s_interlinks_num for _ in range(self.s_g_num)] for _ in range(self.g_num)]
        while sum(map(sum, number_inter_links)) > 0:
            logger.debug(str(number_inter_links))
            g1_i, g2_i = randint(0, self.g_num - 1), randint(0, self.g_num - 1)
            sw1_i, sw2_i = randint(0, self.s_g_num - 1), randint(0, self.s_g_num - 1)
            if g1_i != g2_i and number_inter_links[g1_i][sw1_i] > 0 and number_inter_links[g2_i][sw2_i] > 0:
                self.addLink(
                    groups_switches[g1_i][sw1_i], 
                    groups_switches[g2_i][sw2_i],
                    loss=10 if (int(randint(0, 100)) < self.loss_prob) else 0,
                    **linkopts)
                number_inter_links[g1_i][sw1_i] -= 1
                number_inter_links[g2_i][sw2_i] -= 1


def dump_etc_hosts(net):
    f = open(os.getenv('VOLUME') + '/etc_hosts', "a")
    for d in net.hosts:
        f.write(d.IP() + ' ' + d.name + '\n')
    f.close()

def dump_mpi_hosts_file(net):
    f = open(os.getenv('VOLUME') + '/mpi_hosts_file', "a")
    for d in net.hosts:
        f.write(d.name + '\n')
    f.close()

def run_set_ssh(net):
    for d in net.hosts:
        d.cmd('/data/set_ssh.sh start')

def createTopo(g=4, a=None, p=1, h=1, bw_sw_h=0.2, bw_inn_sw=0.5, bw_int_sw=0.7, ip="127.0.0.1", port=6633):
    if a is None: a = g - 1 # Canonical Topo
    logging.debug("LV1 Create DragonFly")
    topo = DragonFly(g, a, p, h)
    topo.createTopo(bw_sw_h=bw_sw_h, bw_inn_sw=bw_inn_sw, bw_int_sw=bw_int_sw)

    logging.debug("LV1 Start Mininet")
    CONTROLLER_IP = ip
    CONTROLLER_PORT = port
    net = Containernet(topo=topo, link=TCLink, controller=None, autoSetMacs=True,
                  autoStaticArp=True)
    net.addController(
        'controller', controller=RemoteController,
        ip=CONTROLLER_IP, port=CONTROLLER_PORT)
    net.start()

    dump_etc_hosts(net)
    dump_mpi_hosts_file(net)
    run_set_ssh(net)

    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    if os.getuid() != 0:
        logger.debug("You are NOT root")
    elif os.getuid() == 0:
        createTopo(
            int(os.getenv('NUM_GROUPS', default=4)),
            int(os.getenv('NUM_SW_IN_GROUP', default=3)),
            int(os.getenv('NUM_HOSTS_FOR_SW', default=1)),
            int(os.getenv('NUM_INTER_LINKS', default=1))
        )
