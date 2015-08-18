using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WarehouseFramework.Metadata
{
	public class StarSchemaReference
	{
		public string Prefix { get; set; }
		public Reference Reference { get; set; }

		public StarSchemaReference()
			: this(String.Empty, new Reference())
		{ }

		public StarSchemaReference(string prefix, Reference reference)
		{
			this.Prefix = prefix;
			this.Reference = reference;
		}
	}
}
