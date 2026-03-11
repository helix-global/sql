using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObjectStatementPhrase("SET")]
    [SqlScriptObjectStatementPhrase("CREATE ASSEMBLY")]
    [SqlScriptObjectStatementPhrase("CREATE AGGREGATE")]
    internal class SqlScriptFactoryStatement : SqlScriptObject
        {
        public virtual IList<SqlScriptObject> Statements { get; }

        #region ctor{IServiceProvider,SqlCodeObject}
        [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
        public SqlScriptFactoryStatement(IServiceProvider context,SqlCodeObject source)
            : base(context,source)
            {
            if (String.IsNullOrWhiteSpace(source.Sql)) { throw new ArgumentOutOfRangeException(nameof(source)); }
            var parser = TSqlParser.CreateParser(SqlVersion.Sql170,true);
            ProcessFragment(parser.Parse(new StringReader(source.Sql),out var errors),out var statements);
            Statements = statements;
            }
        #endregion
        #region M:ProcessFragment(TSqlFragment,{out}IList<SqlScriptObject>)
        protected virtual void ProcessFragment(TSqlFragment fragment,out IList<SqlScriptObject> statements)
            {
            statements = new List<SqlScriptObject>();
            foreach (var batch in ((TSqlScript)fragment).Batches) {
                foreach (var statement in batch.Statements)
                    {
                    statements.Add(SqlScriptObjectConverter.CreateFrom(Context,statement));
                    }
                }
            statements = statements.AsReadOnly();
            }
        #endregion
        }
    }