using System;
using System.Collections.Generic;

namespace WarehouseFramework.Metadata
{
	public class Package
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public bool IsDefault { get; set; }
		public List<TableOrder> TableOrders { get; set; }

		public Package()
			: this(0, String.Empty, false)
		{ }

		public Package(int id, string name, bool isDefault)
		{
			this.Id = id;
			this.Name = name;
			this.IsDefault = isDefault;
			this.TableOrders = new List<TableOrder>();
		}
	}
}
