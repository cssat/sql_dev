using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using WarehouseFramework.Metadata;

namespace WarehouseFramework
{
	public class Database
	{
		private static string connectionString = "Server=POC2;Database=CA_ODS;Trusted_Connection=true";
		private List<string> databaseTables { get; set; }

		public Dictionary<int, DataType> DataTypes { get; private set; }
		public Dictionary<int, ColumnType> ColumnTypes { get; private set; }
		public Dictionary<int, TableType> TableTypes { get; private set; }
		public Dictionary<int, Dimension> Dimensions { get; private set; }
		public Dictionary<int, Table> Tables { get; private set; }
		public Dictionary<int, Column> Columns { get; private set; }
		public Dictionary<int, Reference> References { get; private set; }
		public Dictionary<int, Package> Packages { get; private set; }
		public Dictionary<int, TableOrder> TableOrders { get; private set; }
		public Dictionary<long, EntityKey> EntityKeys { get; private set; }

		public Database()
		{
			this.databaseTables = new List<string>();
			this.DataTypes = new Dictionary<int, DataType>();
			this.ColumnTypes = new Dictionary<int, ColumnType>();
			this.TableTypes = new Dictionary<int, TableType>();
			this.Dimensions = new Dictionary<int, Dimension>();
			this.Tables = new Dictionary<int, Table>();
			this.Columns = new Dictionary<int, Column>();
			this.References = new Dictionary<int, Reference>();
			this.Packages = new Dictionary<int, Package>();
			this.TableOrders = new Dictionary<int, TableOrder>();
			this.EntityKeys = new Dictionary<long, EntityKey>();
		}

		public void LoadMetadata()
		{
			try
			{
				SqlConnection connection = new SqlConnection(connectionString);
				connection.Open();
				GetDataTypes(connection);
				GetColumnTypes(connection);
				GetTableTypes(connection);
				GetDimensions(connection);
				GetTables(connection);
				GetColumns(connection);
				GetReferences(connection);
				LinkMetadata();
				connection.Close();
				connection.Dispose();
			}
			catch (DataException)
			{
				throw;
			}
			catch (Exception e)
			{
				string message = String.Format("A problem occurred while connecting to the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetDataTypes(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_data_type_id, data_type_name FROM rodis_wh.wh_data_type";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					DataTypes.Add(id, new DataType(id, name));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetColumnTypes(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_column_type_id, wh_column_type FROM rodis_wh.wh_column_type";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					ColumnTypes.Add(id, new ColumnType(id, name));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetTableTypes(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_table_type_id, wh_table_type, table_name_ending FROM rodis_wh.wh_table_type";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					string tableNameEnding = reader.GetString(2);
					TableTypes.Add(id, new TableType(id, name, tableNameEnding));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetDimensions(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_dimension_id, wh_dimension_name FROM rodis_wh.wh_dimension";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					Dimensions.Add(id, new Dimension(id, name));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetTables(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_table_id, wh_table_name, wh_table_type_id, wh_dimension_id FROM rodis_wh.wh_table";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					int tableTypeId = reader.GetInt32(2);
					int dimensionId = 0;
					bool hasDimension = int.TryParse(reader.GetValue(3).ToString(), out dimensionId);
					Tables.Add(id, new Table(id, name, TableTypes[tableTypeId], hasDimension ? Dimensions[dimensionId] : new Dimension()));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetColumns(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_column_id, wh_column_name, wh_column_type_id, wh_table_id, wh_data_type_id, data_length, max_length, ordinal FROM rodis_wh.wh_column";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					int columnTypeId = reader.GetInt32(2);
					int tableId = reader.GetInt32(3);
					int dataTypeId = reader.GetInt32(4);
					int dataLength = reader.GetInt32(5);
					bool isMaxLength = reader.GetBoolean(6);
					int ordinal = reader.GetInt32(7);
					Columns.Add(id, new Column(id, name, ColumnTypes[columnTypeId], Tables[tableId], DataTypes[dataTypeId], dataLength, isMaxLength, ordinal));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetReferences(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_reference_id, pr_wh_table_id, ref_wh_table_id, ref_role, is_required FROM rodis_wh.wh_reference";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					int primaryTableId = reader.GetInt32(1);
					int referenceTableId = reader.GetInt32(2);
					object roleObject = reader.GetValue(3);
					string role = roleObject == null ? String.Empty : roleObject.ToString();
					bool isRequred = reader.GetBoolean(4);
					References.Add(id, new Reference(id, Tables[primaryTableId], Tables[referenceTableId], role, isRequred));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetPackages(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_package_id, wh_package_name, is_default FROM rodis_wh.wh_package";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					string name = reader.GetString(1);
					bool isDefault = reader.GetBoolean(2);
					Packages.Add(id, new Package(id, name, isDefault));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetTableOrders(SqlConnection connection)
		{
			try
			{
				string query = "SELECT wh_table_order_id, wh_package_id, wh_table_id, step_number FROM rodis_wh.wh_table_order";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int id = reader.GetInt32(0);
					int packageId = reader.GetInt32(1);
					int tableId = reader.GetInt32(2);
					int stepNumber = reader.GetInt32(3);
					TableOrders.Add(id, new TableOrder(id, Packages[packageId], Tables[tableId], stepNumber));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetEntityKeys(SqlConnection connection)
		{
			try
			{
				string query = "SELECT entity_key, wh_column_id, source_key FROM rodis_wh.wh_entity_key";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					int entityKey = reader.GetInt32(0);
					int columnId = reader.GetInt32(1);
					string sourceKey = reader.GetString(2);
					EntityKeys.Add(entityKey, new EntityKey(entityKey, Columns[columnId], sourceKey));
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void GetDatabaseTables(SqlConnection connection)
		{
			try
			{
				string query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'rodis_wh' AND TABLE_NAME NOT LIKE 'wh_%'";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();

				while (reader.Read())
				{
					string tableName = reader.GetString(0);
					databaseTables.Add(tableName);
				}

				reader.Close();
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while reading from the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void LinkMetadata()
		{
			foreach (var item in ColumnTypes.Values)
			{
				item.Columns = Columns.Values.Where(p => p.ColumnType.Id == item.Id).ToList();
			}

			foreach (var item in DataTypes.Values)
			{
				item.Columns = Columns.Values.Where(p => p.DataType.Id == item.Id).ToList();
			}

			foreach (var item in Tables.Values)
			{
				item.Columns = Columns.Values.Where(p => p.Table.Id == item.Id).ToList();
				item.PrimaryReferences = References.Values.Where(p => p.PrimaryTable.Id == item.Id).ToList();
				item.References = References.Values.Where(p => p.ReferencingTable.Id == item.Id).ToList();
			}

			foreach (var item in Dimensions.Values)
			{
				item.Tables = Tables.Values.Where(p => p.Dimension.Id == item.Id).ToList();
			}

			foreach (var item in Packages.Values)
			{
				item.TableOrders = TableOrders.Values.Where(p => p.Package.Id == item.Id).ToList();
			}
		}

		public void BuildWarehouseTables()
		{
			try
			{
				SqlConnection connection = new SqlConnection(connectionString);
				connection.Open();
				CreateDefaultTableOrder(connection);
				CreateAttributeTables(connection);
				CreateAttributeTableRelationships(connection);
				CreateDimensionTables(connection);
				CreateFactTables(connection);
				connection.Close();
				connection.Dispose();
			}
			catch (DataException)
			{
				throw;
			}
			catch (Exception e)
			{
				string message = String.Format("A problem occurred while connecting to the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void CreateDefaultTableOrder(SqlConnection connection)
		{
			List<TableOrder> newTableOrders = new List<TableOrder>();
			var packageId = Packages.Count == 0 ? 1 : Packages.Values.Select(s => s.Id).Max() + 1;
			var tableOrderId = TableOrders.Count == 0 ? 1 : TableOrders.Values.Select(s => s.Id).Max() + 1;
			Package defaultPackage = Packages.FirstOrDefault(p => p.Value.IsDefault).Value ?? new Package(packageId, "Default", true);
			int attTablesCount = Tables.Count(p => p.Value.TableType.Id != 2);
			int step = 1;

			while (newTableOrders.Count < attTablesCount)
			{
				var newTableOrderTableIds = newTableOrders.Select(s => s.Table.Id);
				var remainingTableIds = Tables.Values.Where(p => !newTableOrderTableIds.Contains(p.Id) && !p.IsFactTable).Select(s => s.Id);
				var remainingReferencedTableIds = new List<int>();
				
				if (step == 1)
					remainingReferencedTableIds = References.Values.Where(p => !newTableOrderTableIds.Contains(p.ReferencingTable.Id) && !p.ReferencingTable.IsFactTable).Select(s => s.ReferencingTable.Id).Distinct().ToList();
				else
					remainingReferencedTableIds = References.Values.Where(p => !newTableOrderTableIds.Contains(p.PrimaryTable.Id) && !p.ReferencingTable.IsFactTable).Select(s => s.ReferencingTable.Id).Distinct().ToList();
				
				var tableSet = Tables.Values.Where(p => remainingTableIds.Contains(p.Id) && !remainingReferencedTableIds.Contains(p.Id));

				foreach (var item in tableSet)
				{
					newTableOrders.Add(new TableOrder(tableOrderId, defaultPackage, item, step));
					tableOrderId++;
				}

				step++;
			}

			foreach (var item in Tables.Values.Where(p => p.IsFactTable))
			{
				newTableOrders.Add(new TableOrder(tableOrderId, defaultPackage, item, step));
				tableOrderId++;
			}

			if (Packages.Values.FirstOrDefault(p => p.IsDefault) == null)
			{
				Packages.Add(packageId, defaultPackage);
				foreach (var item in newTableOrders)
				{
					TableOrders.Add(item.Id, item);
				}
			}
			else
			{
				List<int> ids = TableOrders.Where(p => p.Value.Package.IsDefault).Select(s => s.Key).ToList<int>();
				
				foreach (var item in ids)
				{
					TableOrders.Remove(item);
				}

				Packages[defaultPackage.Id] = defaultPackage;

				foreach (var item in newTableOrders)
				{
					TableOrders.Add(item.Id, item);
				}
			}

			foreach (var item in Packages.Values.Where(p => p.IsDefault))
			{
				item.TableOrders = TableOrders.Values.Where(p => p.Package.Id == item.Id).ToList();
			}

			try
			{
				string query = "DELETE FROM rodis_wh.wh_table_order";
				SqlCommand command = new SqlCommand(query, connection);
				command.ExecuteNonQuery();
				command.CommandText = "DELETE FROM rodis_wh.wh_package";
				command.ExecuteNonQuery();

				foreach (var item in Packages.Values)
				{
					query = String.Format("INSERT rodis_wh.wh_package(wh_package_id, wh_package_name, is_default) VALUES ({0}, '{1}', {2})",
						item.Id, item.Name, item.IsDefault ? 1 : 0);
					command.CommandText = query;
					command.ExecuteNonQuery();
				}

				foreach (var item in TableOrders.Values)
				{
					query = String.Format("INSERT rodis_wh.wh_table_order(wh_table_order_id, wh_package_id, wh_table_id, step_number) VALUES ({0}, {1}, {2}, {3})",
						item.Id, item.Package.Id, item.Table.Id, item.StepNumber);
					command.CommandText = query;
					command.ExecuteNonQuery();
				}
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while updating the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void CreateAttributeTables(SqlConnection connection)
		{
			try
			{
				string query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'rodis_wh' AND (TABLE_NAME LIKE '%_att' OR TABLE_NAME LIKE '%_fat') AND TABLE_NAME NOT LIKE 'staging_%'";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();
				List<string> dbAttributeTables = new List<string>();

				while (reader.Read())
				{
					string tableName = reader.GetString(0);
					dbAttributeTables.Add(tableName);
				}

				reader.Close();

				foreach (var item in dbAttributeTables.OrderByDescending(ks => Packages.Values.Where(p => p.IsDefault).SelectMany(s => s.TableOrders).FirstOrDefault(p => p.Table.DbTableName == ks).StepNumber))
				{
					command.CommandText = String.Format("DROP TABLE [rodis_wh].[{0}]", item);
					command.ExecuteNonQuery();
				}

				foreach (var table in Tables.Values)
				{
					query = String.Format("CREATE TABLE [rodis_wh].[{0}](", table.DbTableName);

					foreach (var column in table.Columns.OrderBy(ks => ks.Ordinal))
					{
						query = String.Concat(query, String.Format("\n\t[{0}] {1} {2}NULL", column.Name, column.GetDbDataType(), column.isAttributeColumn ? String.Empty : "NOT "));

						if (column.isKeyColumn)
						{
							query = String.Concat(query, String.Format("\n\t\tCONSTRAINT [pk_{0}] PRIMARY KEY", table.DbTableName));
						}

						query = String.Concat(query, ",");
					}

					query = String.Concat(query.TrimEnd(','), "\n)");

					command.CommandText = query;
					command.ExecuteNonQuery();
					
					query = String.Format("CREATE UNIQUE NONCLUSTERED INDEX [idx_{0}_{1}] ON [rodis_wh].[{0}] ([{1}])",
						table.DbTableName, table.GetSourceKeyColumn().Name);

					command.CommandText = query;
					command.ExecuteNonQuery();
				}
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while updating the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void CreateAttributeTableRelationships(SqlConnection connection)
		{
			try
			{
				foreach (var item in References.Values)
				{
					string query = String.Format("ALTER TABLE [rodis_wh].[{0}] ADD [{1}] {2} NOT NULL",
						item.ReferencingTable.DbTableName, item.GetRefColumnName(), item.GetDbDataType());
					SqlCommand command = new SqlCommand(query, connection);
					command.ExecuteNonQuery();

					query = String.Format("ALTER TABLE [rodis_wh].[{0}] WITH CHECK ADD  CONSTRAINT [fk_{0}_{1}] FOREIGN KEY([{1}])\nREFERENCES [rodis_wh].[{2}] ([{3}])",
						item.ReferencingTable.DbTableName, item.GetRefColumnName(), item.PrimaryTable.DbTableName, item.GetPrimaryColumnName());
					command.CommandText = query;
					command.ExecuteNonQuery();

					query = String.Format("ALTER TABLE [rodis_wh].[{0}] CHECK CONSTRAINT [fk_{0}_{1}]", item.ReferencingTable.DbTableName, item.GetRefColumnName());
					command.CommandText = query;
					command.ExecuteNonQuery();

					query = String.Format("CREATE NONCLUSTERED INDEX [idx_{0}_{1}] ON [rodis_wh].[{0}] ([{1}])", item.ReferencingTable.DbTableName, item.GetRefColumnName());
					command.CommandText = query;
					command.ExecuteNonQuery();
				}
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while updating the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void CreateDimensionTables(SqlConnection connection)
		{
			try
			{
				string query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'rodis_wh' AND TABLE_NAME LIKE '%_dim'";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();
				List<string> dbDimensionTables = new List<string>();

				while (reader.Read())
				{
					string tableName = reader.GetString(0);
					dbDimensionTables.Add(tableName);
				}

				reader.Close();

				foreach (var item in dbDimensionTables)
				{
					command.CommandText = String.Format("DROP TABLE [rodis_wh].[{0}]", item);
					command.ExecuteNonQuery();
				}

				foreach (var dim in Dimensions.Values)
				{
					query = String.Format("CREATE TABLE [rodis_wh].[{0}_dim](", dim.Name);

					foreach (var table in dim.Tables)
					{
						foreach (var column in table.Columns.OrderBy(ks => ks.Ordinal))
						{
							query = String.Concat(query, String.Format("\n\t[{0}] {1} {2}NULL,", column.Name, column.GetDbDataType(), column.isAttributeColumn ? String.Empty : "NOT "));
						}
					}

					foreach (var item in dim.GetReferences())
					{
						query = String.Concat(query, String.Format("\n\t[{0}] {1} NOT NULL,", item.GetRefColumnName(), item.GetDbDataType()));
					}

					query = String.Concat(query.TrimEnd(','), "\n)");
					command.CommandText = query;
					command.ExecuteNonQuery();
				}
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while updating the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}

		private void CreateFactTables(SqlConnection connection)
		{
			try
			{
				string query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'rodis_wh' AND TABLE_NAME LIKE '%_fact'";
				SqlCommand command = new SqlCommand(query, connection);
				SqlDataReader reader = command.ExecuteReader();
				List<string> dbFactTables = new List<string>();

				while (reader.Read())
				{
					string tableName = reader.GetString(0);
					dbFactTables.Add(tableName);
				}

				reader.Close();

				foreach (var item in dbFactTables)
				{
					command.CommandText = String.Format("DROP TABLE [rodis_wh].[{0}]", item);
					command.ExecuteNonQuery();
				}

				foreach (var table in Tables.Values.Where(p => p.IsFactTable))
				{
					query = String.Format("CREATE TABLE [rodis_wh].[{0}_fact](", table.Name);

					foreach (var column in table.Columns)
					{
						query = String.Concat(query, String.Format("\n\t[{0}] {1} {2}NULL,", column.Name, column.GetDbDataType(), column.isAttributeColumn ? String.Empty : "NOT "));
					}

					foreach (var item in table.GetStarSchemaReferences())
					{
						query = String.Concat(query, String.Format("\n\t[{0}{1}] {2} NOT NULL,",
							String.IsNullOrEmpty(item.Prefix) ? String.Empty : String.Concat(item.Prefix, "_"), item.Reference.GetRefColumnName(), item.Reference.GetDbDataType()));
					}

					query = String.Concat(query.TrimEnd(','), "\n)");
					command.CommandText = query;
					command.ExecuteNonQuery();
				}
			}
			catch (SqlException e)
			{
				string message = String.Format("A problem occurred while updating the database:\n{0}", e.Message);
				throw new DatabaseException(message, e);
			}
		}
	}

	public class DatabaseException : Exception
	{
		public DatabaseException()
			: base()
		{ }

		public DatabaseException(string message)
			: base(message)
		{ }

		public DatabaseException(string message, Exception inner)
			: base(message, inner)
		{ }
	}
}
