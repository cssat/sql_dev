using System;

namespace WarehouseFramework.Metadata
{
    public class TableType
    {
		public int Id { get; set; }
		public string Name { get; set; }
		public string TableNameEnding { get; set; }

		public TableType()
			: this(0, String.Empty, String.Empty)
		{ }

		public TableType(int id, string name, string tableNameEnding)
		{
			this.Id = id;
			this.Name = name;
			this.TableNameEnding = tableNameEnding;
		}
	}
}
