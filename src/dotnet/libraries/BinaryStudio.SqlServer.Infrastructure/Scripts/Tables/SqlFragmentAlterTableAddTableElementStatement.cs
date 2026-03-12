using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AlterTableAddTableElementStatement))]
    internal sealed class SqlFragmentAlterTableAddTableElementStatement : SqlFragmentAlterTableStatement<AlterTableAddTableElementStatement>
        {
        [UsedImplicitly][Field] public ISqlScriptTableDefinition Definition { get; }

        #region ctor{IServiceProvider,AlterTableAddTableElementStatement}
        public SqlFragmentAlterTableAddTableElementStatement(IServiceProvider context,AlterTableAddTableElementStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }