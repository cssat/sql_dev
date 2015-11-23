using System;
using System.Collections.Generic;

namespace WarehouseFramework.Metadata
{
	public class Reference
	{
		public int Id { get; set; }
		public Table PrimaryTable { get; set; }
		public Table ReferencingTable { get; set; }
		public string ReferenceRole { get; set; }
		public bool IsRequired { get; set; }

		public bool IsExtradimensional
		{
			get { return PrimaryTable.Dimension.Id != ReferencingTable.Dimension.Id; }
		}

		public Reference()
			: this(0, new Table(), new Table(), String.Empty, false)
		{ }

		public Reference(int id, Table primaryTable, Table referencingTable, string referenceRole, bool isRequired)
		{
			this.Id = id;
			this.PrimaryTable = primaryTable;
			this.ReferencingTable = referencingTable;
			this.ReferenceRole = referenceRole;
			this.IsRequired = isRequired;
		}

		public string GetPrimaryColumnName()
		{
			return PrimaryTable.GetKeyColumn().Name;
		}

		public string GetDbDataType()
		{
			return PrimaryTable.GetKeyColumn().GetDbDataType();
		}

		public string GetRefColumnName()
		{
			return String.Concat(PrimaryTable.GetKeyColumn().Name, !String.IsNullOrEmpty(ReferenceRole) ? "_" : String.Empty, ReferenceRole);
		}

		public string GetRefDimName()
		{
			return ReferencingTable.Dimension.Name;
		}

		public List<Reference> GetPrimaryDimRefs()
		{
			return PrimaryTable.Dimension.GetReferences();
		}
	}
}
