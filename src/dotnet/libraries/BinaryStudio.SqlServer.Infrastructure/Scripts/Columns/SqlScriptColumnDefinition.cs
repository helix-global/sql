using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptColumnDefinition<T> : SqlScriptCodeObject<T>,ISqlScriptColumnDefinition,ISqlColumn
        where T: SqlColumnDefinition
        {
        public SqlObjectIdentifier QualifiedName { get; }
        public virtual Boolean IsComputed { get { return false; }}
        public String Description { get;set; }
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }
        [UsedImplicitly][Field] public SqlGeneratedAlwaysType GeneratedAlwaysType { get; }
        [UsedImplicitly][Field] public SqlSparseOption SparseOption { get; }
        [UsedImplicitly][Field] public SqlScriptDataTypeSpecification DataType { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptConstraint> Constraints { get; }
        ISqlTypeSpecifier ISqlColumn.TypeSpecifier { get { return DataType; }}
        IList<ISqlConstraint> ISqlColumn.Constraints { get { return Constraints.OfType<ISqlConstraint>().AsReadOnly(); }}

        #region ctor{IServiceProvider,T}
        [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
        protected SqlScriptColumnDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            QualifiedName = SqlObjectIdentifier.Create(new []{ Name });
            if (source.Parent.Parent is SqlCreateTableStatement statement) {
                var TableName = (SqlObjectIdentifier)CoerceValue(typeof(SqlObjectIdentifier),null,statement.Name);
                if (TableName.SchemaName == SqlIdentifier.Null) { TableName = "dbo" + TableName; }
                QualifiedName = TableName + Name;
                }
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlColumnDefinition))]
    internal class SqlScriptColumnDefinition : SqlScriptColumnDefinition<SqlColumnDefinition>
        {
        #region ctor{IServiceProvider,SqlColumnDefinition}
        public SqlScriptColumnDefinition(IServiceProvider context,SqlColumnDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }