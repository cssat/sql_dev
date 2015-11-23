using System;

namespace WarehouseFramework.Metadata
{
	public class EntityKey
	{
		public int WarehouseKey { get; set; }
		public Column Column { get; set; }
		public string SourceKey { get; set; }

		public EntityKey()
			: this(0, new Column(), String.Empty)
		{ }

		public EntityKey(int warehouseKey, Column column, string sourceKey)
		{
			this.WarehouseKey = warehouseKey;
			this.Column = column;
			this.SourceKey = sourceKey;
		}
	}
}
