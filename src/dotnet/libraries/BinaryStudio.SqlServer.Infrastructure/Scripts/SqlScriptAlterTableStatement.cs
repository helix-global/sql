using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptAlterTableStatement<T> : SqlScriptDomObject<T>,ISqlScriptStatement
        where T : AlterTableStatement
        {
        public String StatementPhrase { get { return "ALTER TABLE"; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptAlterTableStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }