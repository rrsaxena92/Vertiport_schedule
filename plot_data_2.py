import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42

figFolder = "E:/Digital_Twin_and_UAM/Figures"


folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
filename = "LongerTimeSeprationFCFSNoSeq"
ext = ".csv"


vertdf_dir = pd.read_csv(folder + "/" + filename + ext)

""" Box PLots 
ht = 5; asp = 2
g = sns.catplot(data=vertdf_dir, x="Num_directions", y="Delay", hue="Num_flights", kind="box", showmeans=True, meanprops={"marker": ".",
                       "markeredgecolor": "black","markersize": "5"}, height=ht, aspect=asp, palette="hls")

g.set(yticks=range(0,int(max(vertdf_dir["Delay"])+5),50))
g.set_ylabels("Delay (s)")
g.set_xlabels("Number of Surface Directions")
g._legend.set_title("Number of Flights")
sns.move_legend(g, "upper right")
plt.grid(axis='y')
plt.tight_layout()
plt.savefig(figFolder + "/" + filename + ".png", dpi=600)
"""

"""
fig,ax = plt.subplots(figsize=(10,5))
g1 = sns.boxplot(data=vertdf_dir, x="Num_directions", y="Delay", hue="Num_flights", showmeans=True, meanprops={"marker": ".",
                       "markeredgecolor": "black","markersize": "5"},  palette="hls", fill=True, ax=ax)

ax.set_ylabel("Delay (s)")
ax.set_xlabel("Number of Surface Directions")

# Setting labels and limits
ax.set(yticks=range(0,int(max(vertdf_dir["Delay"])+5),150))
#ax.set(yticks=range(0,3750,150))
#ax.set_ylim([-100,3800])
ax.legend(title="Number of Flights (MILP)", loc="upper right")
ax.grid(axis='y')

# Show the plots
plt.tight_layout()
# plt.savefig(figFolder + "/" + filename + ".png", dpi=600)
"""

# """ #FCFS
"""
folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
filename = "LongerTimeSeprationFCFSNoSeq"
ext = ".csv"

vertdf_dir = pd.read_csv(folder + "/" + filename + ext)
# _,ax = plt.subplots(figsize=(10,5))
# # Set the alpha value for the palette colors
# translucent_palette = sns.color_palette("hls")
# translucent_palette_rgba = [(r, g, b, 0) for r, g, b in translucent_palette]

g2 = sns.boxplot(data=vertdf_dir, x="Num_directions", y="Delay", hue="Num_flights", showmeans=True, meanprops={"marker": "o",
                       "markeredgecolor": "black","markersize": "5"}, fill=False, ax=ax, legend=True,  palette="Set2")#palette="hls", desat=0.3)

# Adjust labels and ticks
# ax.set_ylabel("Delay (s)")
# ax.set_xlabel("Number of Surface Directions")

# Setting labels and limits
# ax.set(yticks=range(0,int(max(vertdf_dir["Delay"])+5),150))
# ax.set(yticks=range(0,3750,150))
# ax.set_ylim([-100,3800])
# ax.legend(title="Number of Flights (FCFS)", loc="upper center")
# ax.grid(axis='y')

# Show the plots
plt.tight_layout()
plt.savefig(figFolder + "/" + filename + ".png", dpi=600)

"""

""" Bar plots """
folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/FCFS" # Throughput
filename = "flight_sol_40_2024_02_17_11_30_14"
ext = ".csv"


# Columns to extract from each file
columns_to_extract = ['delay', "DepGateDelay","DepTaxidelay","DepOFVdelay","DepfixDelay"]
vertdf_dir = pd.read_csv(folder + "/" + filename + ext, usecols=columns_to_extract)

ylim = max(vertdf_dir["delay"])
del vertdf_dir["delay"]
title = "FCFS 4 direction"
fig, axes = plt.subplots(figsize=(6,5))
vertdf_dir.plot(kind='bar', ax=axes, stacked=True, ylim=[0,ylim])
axes.set_xlabel("Flight index")
axes.set_ylabel("Delay (s)")
axes.set_title(title)
axes.grid(axis='y')
plt.tight_layout()
plt.savefig(figFolder + "/" + title + ".png", dpi=600, transparent=True)
# """

plt.show()