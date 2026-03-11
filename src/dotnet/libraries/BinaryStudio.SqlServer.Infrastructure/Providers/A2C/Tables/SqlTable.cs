using System;
using System.Collections.Generic;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlTable : ISqlTable,ISqlQualifiedObject
        {
        public SqlObjectIdentifier QualifiedName { get; }
        public Boolean IsAnsiNullsOn { get;set; }
        public Boolean IsLargeValueTypesOutOfRow { get;set; }
        public Boolean IsTableLockOnBulkLoad { get;set; }
        public Int32 TextInRowSize { get;set; }
        public SqlLockEscalationMethod LockEscalation { get;set; }
        public IList<ISqlColumn> Columns { get; }
        public IList<ISqlConstraint> Constraints { get; } = new List<ISqlConstraint>();

        public SqlTable(SqlScriptCreateTableStatement source)
            {
            QualifiedName = source.Name;
            Columns = source.Definition.ColumnDefinitions.Select(From).AsReadOnly();
            Constraints.AddRange(source.Definition.Constraints);
            return;
            }

        private ISqlColumn From(ISqlScriptColumnDefinition source) {
            return new SqlColumn(this,source);
            }
        }
    }