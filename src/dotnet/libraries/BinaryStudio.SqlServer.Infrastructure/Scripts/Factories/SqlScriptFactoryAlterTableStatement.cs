using System;
using System.Collections.Generic;
using System.Linq;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [UsedImplicitly]
    [SqlScriptObjectStatementPhrase("ALTER TABLE")]
    internal class SqlScriptFactoryAlterTableStatement : SqlScriptFactoryStatement
        {
        #region ctor{IServiceProvider,SqlCodeObject}
        public SqlScriptFactoryAlterTableStatement(IServiceProvider context,SqlCodeObject source)
            : base(context,source)
            {
            }
        #endregion
        #region M:ProcessFragment(TSqlFragment,{out}IList<SqlScriptObject>)
        protected override void ProcessFragment(TSqlFragment fragment,out IList<SqlScriptObject> statements) {
            statements = new List<SqlScriptObject>();
            var r = fragment.Descendants<AlterTableStatement>().FirstOrDefault();
            if (r != null) {
                statements.Add(SqlScriptObjectConverter.CreateFrom(Context,r));
                return;
                }
            base.ProcessFragment(fragment, out statements);
            }
        #endregion
        }
    }