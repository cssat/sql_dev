﻿using System;
using System.Collections.Generic;
using System.Linq;

namespace WarehouseFramework.Metadata
{
	public class Table
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public TableType TableType { get; set; }
		public Dimension Dimension { get; set; }
		public List<Column> Columns { get; set; }
		public List<Reference> PrimaryReferences { get; set; }
		public List<Reference> References { get; set; }

		public bool IsFactTable
		{
			get { return TableType.Id == 2; }
		}

		public Table()
			: this(0, String.Empty, new TableType(), new Dimension())
		{ }

		public Table(int id, string name, TableType tableType, Dimension dimension)
		{
			this.Id = id;
			this.Name = name;
			this.TableType = tableType;
			this.Dimension = dimension;
			this.Columns = new List<Column>();
			this.PrimaryReferences = new List<Reference>();
			this.References = new List<Reference>();
		}

		public Column GetKeyColumn()
		{
			return Columns.FirstOrDefault(p => p.isKeyColumn);
		}

		public Column GetSourceKeyColumn()
		{
			return Columns.FirstOrDefault(p => p.isSourceKeyColumn);
		}

		public Dictionary<string, Reference> GetStarSchemaReferences()
		{
			Dictionary<string, Reference> refList = new Dictionary<string, Reference>();

			if (IsFactTable)
			{
				foreach (var item in References)
				{
					refList.Add(String.Empty, item);
					FindSubReferences(item, String.Empty, ref refList);
				}
			}

			return refList;
		}

		private void FindSubReferences(Reference reference, string prefix, ref Dictionary<string, Reference> refList)
		{
			foreach (var subRef in reference.GetPrimaryDimRefs())
			{
				string newPrefix = String.Concat(!String.IsNullOrEmpty(prefix) ? String.Concat(prefix, "_") : String.Empty, subRef.GetRefDimName());
				refList.Add(newPrefix, subRef);
				FindSubReferences(subRef, prefix, ref refList);
			}
		}
	}
}
