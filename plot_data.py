import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42
    
folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/Results/Experiment_set_2"
filename = "Vertiport_Direction.csv"
figFolder = "E:/Digital_Twin_and_UAM/Figures"

# folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
# filename = "ArrivalsOnlyNoXtopo1"
ext = ".csv"

vertdf_dir = pd.read_csv(folder + "/" + filename)
meandf_dir = pd.DataFrame(columns=["NumFlights", "Directions", "delay"])


k = 0
for i in vertdf_dir["num Flights"].unique():
    for j in vertdf_dir.Directions.unique():
        meandf_dir.loc[k,"NumFlights"] = i
        meandf_dir.loc[k,"Directions"] = j
        meandf_dir.loc[k,"delay"] = vertdf_dir[(vertdf_dir["num Flights"]==i) & (vertdf_dir.Directions==j)].mean().Delay
        k += 1
# fig, ax = plt.subplots()


""" Plots for different direction """
# sns.relplot(data=vertdf_dir, x="num Flights", y="Delay", hue="Directions", kind="line", palette="Set2")
# sns.relplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="line", palette="Set2")
# '''
ht = 5; asp = 2
# sns.catplot(data=vertdf_dir, x="num Flights", y="Delay", hue="Directions", kind="box")
g = sns.catplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="box", showmeans=True,
                meanprops={"marker": ".","markeredgecolor": "black","markersize": "5"}, height=ht, aspect=asp, legend=False)
                # ,legend={"title": "Number of Flights", "fontsize": 14, "fontweight" : 'bold'})
# h = sns.relplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="line", palette="Set2", facet_kws=g)
# plt.plot(meandf_dir.Directions.unique(),meandf_dir[meandf_dir.NumFlights==20].delay)
# plt.ylim([0,140])
g.set(yticks=range(0,int(max(vertdf_dir["Delay"])+5),10))
g.set_ylabels("Delay (s)", fontsize=17) #, fontweight='bold')
g.set_xlabels("Number of Surface Directions", fontsize=17) #, fontweight='bold')
# g._legend.set_title("Number of Flights")

ax = g.axes[0, 0]
ax.legend(title="Number of Flights", prop={"size": 16},  title_fontsize=16)

# Set tick label size and style for x-axis and y-axis
plt.xticks(fontsize=15)#, fontweight='bold')
plt.yticks(fontsize=15) #, fontweight='bold')
plt.tight_layout()
plt.grid(axis='y')
# sns.move_legend(g, "upper right")
# plt.legend(loc="upper left")

plt.savefig(figFolder + "/" + "catplot_direction.png", transparent=True)
# sns.relplot(data=meandf_dir, x="Directions", y="delay", hue="NumFlights", kind="line", palette="Set2", ax=ax2)

"""

Plots for common segment 
folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/Vertiport_schedule/Results/Common_segment"
filename = "verti_common.csv"
vertdf_common = pd.read_csv(folder + "/" + filename)

meandf_ratio = pd.DataFrame(columns=["NumFlights", "Directions", "Delay"])


k = 0
for i in vertdf_common["NumFlights"].unique():
    for j in vertdf_common.Ratio.unique():
        meandf_ratio.loc[k,"NumFlights"] = i
        meandf_ratio.loc[k,"Ratio"] = j
        meandf_ratio.loc[k,"Delay"] = vertdf_common[(vertdf_common["NumFlights"]==i) & (vertdf_common.Ratio==j)].mean().Delay
        k += 1

ht = 5; asp = 2
# sns.catplot(data=vertdf_common, x="NumFlights", y="Delay", hue="Ratio", kind="box")
ax = sns.catplot(data=vertdf_common, x="Ratio", y="Delay", hue="NumFlights", kind="box", showmeans=True, meanprops={"marker": ".",
                       "markeredgecolor": "black","markersize": "5"}, height=ht, aspect=asp, legend=False)
ax.set_ylabels("Delay (s)", fontsize=16) #, fontweight='bold')
ax.set_xlabels(r"Length Ratio $\rho$", fontsize=17) #, fontweight='bold')
# ax._legend.set_title("Number of Flights")
ax.set(yticks=range(0,int(max(vertdf_common["Delay"])+5),10))
leg = ax.axes[0, 0]
leg.legend(title="Number of Flights", prop={"size": 16},  title_fontsize=16)

# sns.move_legend(ax, "upper center")
plt.xticks(fontsize=15) #, fontweight='bold')
plt.yticks(fontsize=15) #, fontweight='bold')
plt.tight_layout()
plt.grid(axis='y')
plt.savefig(figFolder + "/" + "common_dir.pdf", dpi=600)
# '''
# plot a line plot with markers for the means
# sns.lineplot(data=meandf_ratio, x="Ratio", y="Delay", hue="NumFlights", marker='o', ax=ax.ax, legend=False)

# sns.relplot(data=vertdf_common, x="NumFlights", y="Delay", hue="Ratio", kind="line", palette="Set2")
# sns.relplot(data=vertdf_common, x="Ratio", y="Delay", hue="NumFlights", kind="line", palette="Set2")
# df_dir=pd.DataFrame(columns=["num Flights","fix", "Delay"])
#
# df_dir["num Flights"] = vertdf_dir["num Flights"]
# df_dir["fix"] = vertdf_dir["Directions"]
# df_dir["Delay"] = vertdf_dir["Delay"]
#
# ax = sns.catplot(data=df_dir, x="fix", y="Delay", hue="num Flights", kind="box", showmeans=True)
#
# sns.lineplot(data=meandf_ratio, x="Ratio", y="Delay", hue="NumFlights", marker='o', ax=ax.ax, legend=False)


''' A try to put catplot and lineplot in same graph'''
# g = sns.FacetGrid(vertdf_dir)
# g.map_dataframe(sns.boxplot, x="num Flights", y="Delay", hue="Directions")
# g.map_dataframe(sns.lineplot,x="num Flights", y="Delay", hue="Directions")

 Histogram for flights """
# vertdf20 = vertdf_dir[vertdf_dir["num Flights"] == 20]
# # sns.histplot(data=vertdf20, x="Delay", hue="Directions", palette="Set2", multiple="stack")
# # plt.title("All")
# fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(10, 6))
# for i in vertdf20.Directions.unique():
#     vertDirdf20 = vertdf20[vertdf20["Directions"]==i]
#     plt.figure()
#     hist =  sns.histplot(data=vertDirdf20, x="Delay", binwidth=10, binrange=[min(vertdf20["Delay"]), max(vertdf20["Delay"])], ax=axes[i])
#     hist.set_yticks(range(0,10))
#     plt.title("Directions " + str(i))


""" FAIRNESS """

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc"
filename = "Fairness_15F_meanP.csv"
# filename = "Fairness15meanP_Fix.csv"
# filename = "Fairness_15F_meanP_zero.csv"
vertdfFair = pd.read_csv(folder + "/" + filename)

# fig, ax = plt.subplots(figsize=(10,8))
ht = 4; asp = 6
g = sns.catplot(data=vertdfFair, x="P", y="Total Delay", hue="Node", kind="box", showmeans=True,
                 meanprops={"markeredgecolor": "red", "markerfacecolor" : "red"}, legend_out=True,
                height=ht, aspect=asp/ht)
sns.move_legend(g, "upper right")
g.set_ylabels("Delay (s)", fontsize=17) #, fontweight='bold')
g.set_xlabels(fontsize=17) #, fontweight='bold')
g.set(yticks=range(0,50,5))
# ax.add_legend(title="Fairness Type", label_order=["No Fairness", "Gate Delay", "Total Delay"])
# check axes and find which is have legend
# leg = g.axes.flat[0].get_legend()

new_title = 'Fairness Type'
new_labels = ["No Fairness", "Gate Delay", "Total Delay"]
# g._legend.set_title(new_title)
# for t, l in zip(g._legend.texts, new_labels):
#     t.set_text(l)
# g.legend.prop._size = 18
# g.legend.prop._weight = 'bold'
# g.legend(prop={"size": 18})
g._legend.set_visible(False)
ax = g.axes[0, 0]
ax.legend(g.legend.legendHandles, new_labels, title=new_title, prop={"size": 13}, title_fontsize=13)

plt.grid(axis='y')
plt.tight_layout()
plt.xticks(fontsize=15) #, fontweight='bold')
plt.yticks(fontsize=15) #, fontweight='bold')

plt.savefig(figFolder + "/" + "Fairness_box.pdf", dpi=600)
# '''
# dfgateP5 = vertdfFair[(vertdfFair["P"] == 0.05) & (vertdfFair["Node"] == "Gate")]
# dfgateP5.reset_index()
# del dfgateP5["Total Delay"]
#
# fig, ax = plt.subplots()
    # dfgateP5.plot(kind='bar', stacked=True, ax=ax)
# plt.figure()

""" Barplots for fairness"""
fig, axes = plt.subplots(ncols=3, nrows=2, figsize=(16,10))

vertdfFair = vertdfFair[(vertdfFair["Node"]!="No Fair")]
ylim = max(vertdfFair["Total Delay"])
for node,i in zip(vertdfFair.Node.unique(), range(len(vertdfFair.Node.unique()))):
    axes[i,0].set_ylabel("Delay (s)", fontsize=20) #, fontweight='bold')
    for p, j in zip(vertdfFair.P.unique(), range(len(vertdfFair.P.unique()))):
        df = vertdfFair[(vertdfFair["P"] == p) & (vertdfFair["Node"] == node)]
        df.reset_index(inplace=True)
        del df["Total Delay"], df["P"], df["Node"], df["index"]
        df.plot(kind='bar', stacked=True, ax=axes[i,j], ylim=[0,ylim], fontsize=20) #, fontweight='bold')
        axes[i,j].set_title(node + "  |  P  =  " + str(p),  fontsize=22)# ,fontweight='bold')
        axes[1,j].set_xlabel("Flight index", fontsize=22) #, fontweight='bold')
        # axes[1,j].set_ylabel(fontsize=16, fontweight='bold')
        axes[i, j].grid(axis='y')
        axes[i, j].tick_params(axis='x', labelsize=20) # labelweight='bold')
        axes[i,j].legend(fontsize=17, framealpha=0.4) #frameon=False)


        # Set xtick label properties
        for tick in axes[i,j].get_xticklabels():
            pass # tick.set_fontweight('bold')
            
        # Set xtick label properties
        for tick in axes[i, j].get_yticklabels():
            pass # tick.set_fontweight('bold')
            
plt.subplots_adjust(hspace=0.214, wspace=0.107, left=0.052, right=0.974, bottom=0.08, top=0.945)
#plt.legend(fontsize=18)

# Create a FacetGrid with the desired columns and rows

# g = sns.FacetGrid(vertdfFair, col="P", row="Node")
#
# # Define the function to plot the bar plots
# def plot_barplot(data, **kwargs):
#     ax = plt.gca()
#     # ax.bar(data.index, data, **kwargs)
#     # ax.bar(data.index, data["Taxi Delay"], bottom=data[])
#     # ax.bar(data.index, data["Total Delay"], bottom=data["Total Delay"].shift(fill_value=0), **kwargs)
#     ax.bar(data.index, data, bottom=data.shift(fill_value=0), **kwargs)
#     # df.plot(kind='bar', stacked=True, ax=axes[i, j], ylim=[0, ylim])
#
# # Use the map function to plot the bar plots for each facet
# g.map(plot_barplot, "Total Delay")#, ylim=[0, ylim], stacked=True)
#
# # Set the labels and titles
# g.set_axis_labels("Index", "Total Delay")
# g.fig.suptitle("Bar Plots")

# plt.savefig(folder + "/" + "Fair15mean" + ".pdf", dpi=600)
plt.tight_layout()
plt.savefig(figFolder + "/" + "Fair15mean" + ".png", dpi=600, transparent=True)

# plt.grid()

# """
plt.show()