using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal class SqlFragmentColumnDefinition<T> : SqlScriptDomObject<T>,ISqlScriptColumnDefinition
        where T: ColumnDefinitionBase
        {
        [UsedImplicitly][Field(Source="ColumnIdentifier")] public SqlIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        public SqlFragmentColumnDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(ColumnDefinition))]
    internal class SqlFragmentColumnDefinition : SqlFragmentColumnDefinition<ColumnDefinition>
        {
        #region ctor{IServiceProvider,ColumnDefinition}
        public SqlFragmentColumnDefinition(IServiceProvider context,ColumnDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }