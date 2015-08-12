
namespace WarehouseFramework.Metadata
{
	public class TableOrder
	{
		public int Id { get; set; }
		public Package Package { get; set; }
		public Table Table { get; set; }
		public int StepNumber { get; set; }

		public TableOrder()
			: this(0, new Package(), new Table(), 0)
		{ }

		public TableOrder(int id, Package package, Table table, int stepNumber)
		{
			this.Id = id;
			this.Package = package;
			this.Table = table;
			this.StepNumber = stepNumber;
		}
	}
}
