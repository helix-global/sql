using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(TableDefinition))]
    internal class SqlScriptDomTableDefinition : SqlScriptDomObject<TableDefinition>,ISqlScriptTableDefinition
        {
        [UsedImplicitly][Field(EmptyIfNull = true,Source="TableConstraints")] public IList<ISqlScriptConstraint> Constraints { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptColumnDefinition> ColumnDefinitions { get; }

        #region ctor{IServiceProvider,TableDefinition}
        public SqlScriptDomTableDefinition(IServiceProvider context,TableDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }