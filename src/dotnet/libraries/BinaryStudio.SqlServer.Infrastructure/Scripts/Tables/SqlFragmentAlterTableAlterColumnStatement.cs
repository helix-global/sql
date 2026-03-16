using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AlterTableAlterColumnStatement))]
    internal sealed class SqlFragmentAlterTableAlterColumnStatement : SqlFragmentAlterTableStatement<AlterTableAlterColumnStatement>
        {
        #region ctor{IServiceProvider,AlterTableAlterColumnStatement}
        public SqlFragmentAlterTableAlterColumnStatement(IServiceProvider context,AlterTableAlterColumnStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }