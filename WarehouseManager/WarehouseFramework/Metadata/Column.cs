using System;

namespace WarehouseFramework.Metadata
{
	public class Column
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public ColumnType ColumnType { get; set; }
		public Table Table { get; set; }
		public DataType DataType { get; set; }
		public int Length { get; set; }
		public bool IsMax { get; set; }
		public int Ordinal { get; set; }
		
		public bool isKeyColumn
		{
			get { return ColumnType.Id == 1; }
		}

		public bool isSourceKeyColumn
		{
			get { return ColumnType.Id == 2; }
		}

		public bool isAttributeColumn
		{
			get { return ColumnType.Id == 3; }
		}

		public Column()
			: this(0, String.Empty, new ColumnType(), new Table(), new DataType(), 0, false, 0)
		{ }

		public Column(int id, string name, ColumnType columnType, Table table, DataType dataType, int length, bool isMax, int ordinal)
		{
			this.Id = id;
			this.Name = name;
			this.ColumnType = columnType;
			this.Table = table;
			this.DataType = dataType;
			this.Length = length;
			this.IsMax = isMax;
			this.Ordinal = ordinal;
		}

		public string GetDbDataType()
		{
			string len = DataType.Id == 7 ? String.Format("({0})", IsMax ? "MAX" : Length.ToString()) : String.Empty;
			return String.Format("[{0}]{1}", DataType.Name, len);
		}
	}
}
