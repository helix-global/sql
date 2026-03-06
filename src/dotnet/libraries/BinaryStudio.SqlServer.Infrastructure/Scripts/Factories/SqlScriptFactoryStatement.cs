using System;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptFactoryStatement : SqlScriptObject
        {
        public virtual SqlScriptObject Statement { get; }

        #region ctor{IServiceProvider,SqlCodeObject}
        [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
        protected SqlScriptFactoryStatement(IServiceProvider context,SqlCodeObject source)
            : base(context,source)
            {
            if (String.IsNullOrWhiteSpace(source.Sql)) { throw new ArgumentOutOfRangeException(nameof(source)); }
            var parser = TSqlParser.CreateParser(SqlVersion.Sql170,true);
            ProcessFragment(parser.Parse(new StringReader(source.Sql),out var errors),out var statement);
            Statement = statement;
            }
        #endregion
        #region M:ProcessFragment(TSqlFragment,{out}SqlScriptObject)
        protected virtual void ProcessFragment(TSqlFragment fragment,out SqlScriptObject statement)
            {
            statement = default;
            }
        #endregion
        }
    }