using System;
using System.Collections.Generic;
using System.Linq;

namespace WarehouseFramework.Metadata
{
	public class Dimension
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public List<Table> Tables { get; set; }

		public Dimension()
			: this(0, String.Empty)
		{ }

		public Dimension(int id, string name)
		{
			this.Id = id;
			this.Name = name;
			this.Tables = new List<Table>();
		}

		public List<Reference> GetReferences()
		{
			return Tables.SelectMany(s => s.References.Where(p => p.IsExtradimensional)).ToList();
		}
	}
}
