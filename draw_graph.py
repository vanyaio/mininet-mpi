import matplotlib.pyplot as plt
import sys

def draw_all_points(gr):
    x = []
    y = []
    for xi in gr:
        for yi in gr[xi]:
            if (yi == 'inf'):
                continue
            x.append(xi)
            y.append(yi)


    plt.scatter(x, y)
    plt.xlabel('Broken links, %')
    plt.ylabel('Time')
    plt.show()

def draw_average_points(gr):
    x = []
    y = []
    for xi in gr:
        sum = 0
        cnt = 0
        for yi in gr[xi]:
            if (yi == float('inf')):
                continue
            sum += yi
            cnt += 1
        x.append(xi)
        y.append(sum / cnt)

    plt.plot(x, y)
    plt.xlabel('Broken links, %')
    plt.ylabel('Time')
    plt.show()
    print(x)
    print(y)

curr_x = None
gr = dict() #{ xi : [y1,..,yn] }
for line in sys.stdin:
    arr = line.split()
    if (len(arr) == 2):
        curr_x = float(arr[0])
        gr[curr_x] = []
    if (len(arr) == 1):
        gr[curr_x].append(float(arr[0]))

draw_all_points(gr)
draw_average_points(gr)
print(gr)
