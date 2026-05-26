using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptOutputClause<T> : SqlScriptCodeObject<T>
        where T : SqlOutputClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptOutputClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlOutputClause))]
    internal sealed class SqlScriptOutputClause : SqlScriptOutputClause<SqlOutputClause>
        {
        #region ctor{IServiceProvider,SqlOutputClause}
        public SqlScriptOutputClause(IServiceProvider context,SqlOutputClause source)
            : base(context, source)
            {
            }
        #endregion
        }
    }