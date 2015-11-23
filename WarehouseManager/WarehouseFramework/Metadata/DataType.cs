using System;
using System.Collections.Generic;

namespace WarehouseFramework.Metadata
{
	public class DataType
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public List<Column> Columns { get; set; }

		public DataType()
			: this(0, String.Empty)
		{ }

		public DataType(int id, string name)
		{
			this.Id = id;
			this.Name = name;
			this.Columns = new List<Column>();
		}
	}
}
