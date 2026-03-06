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
        #region M:ProcessFragment(TSqlFragment,{out}SqlScriptObject)
        protected override void ProcessFragment(TSqlFragment fragment,out SqlScriptObject statement) {
            statement = default;
            var r = fragment.Descendants<AlterTableStatement>().FirstOrDefault();
            if (r != null) {
                statement = SqlScriptObjectConverter.CreateFrom(Context,r);
                //var rt = r.GetType();
                //if (g_rt.TryGetValue(rt,out var type)) {
                //    var ctor = type.GetConstructor(new[] { typeof(IServiceProvider),r.GetType() });
                //    statement = (SqlScriptCodeObject)ctor.Invoke(new Object[] { Context,r });
                //    return;
                //    }
                //throw (new ArgumentOutOfRangeException(nameof(fragment), $@"No registered type for ""{r.GetType()}""."))
                //    .Add("SourceType",r.GetType().FullName);
                return;
                }
            base.ProcessFragment(fragment, out statement);
            }
        #endregion

        private static readonly IDictionary<Type,Type> g_rt = new Dictionary<Type,Type> {
            {typeof(AlterTableAddTableElementStatement),typeof(SqlScriptAlterTableAddTableElementStatement) },
            {typeof(AlterTableDropTableElementStatement),typeof(SqlScriptAlterTableDropTableElementStatement) },
            {typeof(AlterTableAlterColumnStatement),typeof(SqlScriptAlterTableAlterColumnStatement) }
            };
        }
    }