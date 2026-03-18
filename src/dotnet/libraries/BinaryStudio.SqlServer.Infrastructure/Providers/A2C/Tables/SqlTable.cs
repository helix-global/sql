using System;
using System.Collections.Generic;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal class SqlTable : ISqlTable,ISqlQualifiedObject
        {
        public String Description { get;set; }
        public SqlObjectIdentifier QualifiedName { get; }
        public Boolean IsAnsiNullsOn { get;set; }
        public Boolean IsLargeValueTypesOutOfRow { get;set; }
        public Boolean IsTableLockOnBulkLoad { get;set; }
        public Int32 TextInRowSize { get;set; }
        public SqlLockEscalationMethod LockEscalation { get;set; }
        public IList<ISqlColumn> Columns { get; }
        public IList<ISqlConstraint> Constraints { get; } = new List<ISqlConstraint>();
        public IList<ISqlIndex> Indexes { get; } = new List<ISqlIndex>();
        public IList<ISqlTrigger> Triggers { get; } = new List<ISqlTrigger>();
        private SqlScriptCreateTableStatement source;

        public SqlTable(SqlScriptCreateTableStatement source)
            {
            this.source = source;
            QualifiedName = source.Name;
            Columns = source.Definition.ColumnDefinitions.OfType<ISqlColumn>().AsReadOnly();
            Constraints.AddRange(source.Definition.Constraints);
            return;
            }

        #region M:ToString:String
        public override String ToString()
            {
            return QualifiedName.ToString();
            }
        #endregion
        }
    }