#!/usr/bin/python

#  from mininet.net import Mininet
from mininet.net import Containernet
from mininet.node import Controller
#  from mininet.topo import Topo
from mininet.link import TCLink
from mininet.cli import CLI
import logging
import os

logging.basicConfig(filename='./fattree.log', level=logging.DEBUG)
logger = logging.getLogger(__name__)

#  class FatTree( Topo ):
class FatTree:

    CoreSwitchList = []
    AggSwitchList = []
    EdgeSwitchList = []
    HostList = []

    def __init__( self, k, net):
        " Create Fat Tree topo."
        self.pod = int(k)
        self.iCoreLayerSwitch = int((k/2)**2)
        self.iAggLayerSwitch = int(k*k/2)
        self.iEdgeLayerSwitch = int(k*k/2)
        self.density = int(k/2)
        self.iHost = self.iEdgeLayerSwitch * self.density

        self.bw_c2a = 0.2
        self.bw_a2e = 0.1
        self.bw_h2a = 0.05
        self.net = net

        # Init Topo
        #  Topo.__init__(self)

        self.createTopo()
        logger.debug("Finished topology creation!")

        self.createLink( bw_c2a=self.bw_c2a,
                         bw_a2e=self.bw_a2e,
                         bw_h2a=self.bw_h2a)
        logger.debug("Finished adding links!")

    #    self.set_ovs_protocol_13()
    #    logger.debug("OF is set to version 1.3!")

    def createTopo(self):
        self.createCoreLayerSwitch(self.iCoreLayerSwitch)
        self.createAggLayerSwitch(self.iAggLayerSwitch)
        self.createEdgeLayerSwitch(self.iEdgeLayerSwitch)
        self.createHost(self.iHost)

    """
    Create Switch and Host
    """

    def _addSwitch(self, number, level, switch_list):
        for x in range(1, number+1):
            PREFIX = str(level) + "00"
            if x >= int(10):
                PREFIX = str(level) + "0"
            switch_list.append(self.net.addSwitch('s' + PREFIX + str(x)))

    def createCoreLayerSwitch(self, NUMBER):
        logger.debug("Create Core Layer")
        self._addSwitch(NUMBER, 1, self.CoreSwitchList)

    def createAggLayerSwitch(self, NUMBER):
        logger.debug("Create Agg Layer")
        self._addSwitch(NUMBER, 2, self.AggSwitchList)

    def createEdgeLayerSwitch(self, NUMBER):
        logger.debug("Create Edge Layer")
        self._addSwitch(NUMBER, 3, self.EdgeSwitchList)

    def createHost(self, NUMBER):
        logger.debug("Create Host")
        for x in range(1, NUMBER+1):
            PREFIX = "h00"
            if x >= int(10):
                PREFIX = "h0"
            elif x >= int(100):
                PREFIX = "h"
            #  self.HostList.append(self.addHost(PREFIX + str(x)))
            image="spagnuolocarmine/docker-mpi"
            self.HostList.append(self.net.addDocker(PREFIX + str(x), dimage=image, volumes=["data:/data"]))

    """
    Add Link
    """
    def createLink(self, bw_c2a=0.2, bw_a2e=0.1, bw_h2a=0.5):
        logger.debug("Add link Core to Agg.")
        end = int(self.pod/2)
        for x in range(0, self.iAggLayerSwitch, end):
            for i in range(0, end):
                for j in range(0, end):
                    core_ind = i * end + j
                    agg_ind = x + i
                    linkopts = dict(bw=bw_c2a)

                    if ((core_ind == 0) and (agg_ind == 0)):
                        bw_damaged = bw_c2a #TODO: it should be some other value
                        linkopts = dict(bw=bw_damaged)

                    #  self.net.addLink(
                        #  self.CoreSwitchList[core_ind],
                        #  self.AggSwitchList[agg_ind],
                        #  **linkopts)
                    self.net.addLink(
                        self.CoreSwitchList[core_ind],
                        self.AggSwitchList[agg_ind])

        logger.debug("Add link Agg to Edge.")
        for x in range(0, self.iAggLayerSwitch, end):
            for i in range(0, end):
                for j in range(0, end):
                    linkopts = dict(bw=bw_a2e)
                    #  self.net.addLink(
                        #  self.AggSwitchList[x+i], self.EdgeSwitchList[x+j],
                        #  **linkopts)
                    self.net.addLink(
                        self.AggSwitchList[x+i], self.EdgeSwitchList[x+j])

        logger.debug("Add link Edge to Host.")
        for x in range(0, self.iEdgeLayerSwitch):
            for i in range(0, self.density):
                linkopts = dict(bw=bw_h2a)
                #  self.net.addLink(
                    #  self.EdgeSwitchList[x],
                    #  self.HostList[self.density * x + i],
                    #  **linkopts)
                self.net.addLink(
                    self.EdgeSwitchList[x],
                    self.HostList[self.density * x + i])

        self.net.ping([self.HostList[0], self.HostList[1]])

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

def main():
    k = 4
    #  topo = FatTree(k)
    #  net = Mininet(topo, )
    #  net = Mininet(topo, link=TCLink)
    net = Containernet(controller=Controller)
    net.addController('c0')
    topo = FatTree(k, net)
    net.start()

    dump_etc_hosts(net)
    dump_mpi_hosts_file(net)
    run_set_ssh(net)

    CLI(net)
    net.stop()

if __name__ == '__main__':
    main()
