using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AlterTableAddTableElementStatement))]
    internal sealed class SqlScriptAlterTableAddTableElementStatement : SqlScriptAlterTableStatement<AlterTableAddTableElementStatement>
        {
        [UsedImplicitly][Field] public ISqlScriptTableDefinition Definition { get; }

        #region ctor{IServiceProvider,AlterTableAddTableElementStatement}
        public SqlScriptAlterTableAddTableElementStatement(IServiceProvider context,AlterTableAddTableElementStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }