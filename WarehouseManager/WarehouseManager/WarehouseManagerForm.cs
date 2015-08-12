using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WarehouseFramework;

namespace WarehouseManager
{
	public partial class WarehouseManagerForm : Form
	{
		private Database RodisWarehouse { get; set; }

		public WarehouseManagerForm()
		{
			InitializeComponent();
			RodisWarehouse = new Database();
		}

		private void WarehouseManagerForm_Load(object sender, EventArgs e)
		{
			this.Enabled = false;
			toolStripStatusLabel.Text = "Loading metadata...";
			RodisWarehouse.LoadMetadata();
			toolStripStatusLabel.Text = "Ready";
			this.Enabled = true;
		}

		private void buildWarehouseButton_Click(object sender, EventArgs e)
		{
			this.Enabled = false;
			toolStripStatusLabel.Text = "Building warehouse...";
			RodisWarehouse.BuildWarehouseTables();
			toolStripStatusLabel.Text = "Ready";
			this.Enabled = true;
		}
	}
}
