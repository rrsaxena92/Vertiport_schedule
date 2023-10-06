import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42

figFolder = "E:/Digital_Twin_and_UAM/Figures"

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
filename = "ArrDepTat"
ext = ".csv"

vertdf_dir = pd.read_csv(folder + "/" + filename + ext)

ht = 5; asp = 2
g = sns.catplot(data=vertdf_dir, x="Num_directions", y="Delay", hue="Num_flights", kind="box", showmeans=True, meanprops={"marker": ".",
                       "markeredgecolor": "black","markersize": "5"}, height=ht, aspect=asp)

g.set(yticks=range(0,int(max(vertdf_dir["Delay"])+5),10))
g.set_ylabels("Delay (s)")
g.set_xlabels("Number of Surface Directions")
g._legend.set_title("Number of Flights")
plt.tight_layout()
plt.grid(axis='y')
sns.move_legend(g, "upper right")

plt.show()