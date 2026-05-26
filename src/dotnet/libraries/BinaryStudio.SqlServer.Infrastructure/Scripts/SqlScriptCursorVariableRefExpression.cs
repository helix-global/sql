using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCursorVariableRefExpression<T> : SqlScriptCodeObject<T>
        where T : SqlCursorVariableRefExpression
        {
        public String VariableName {get { return Source.VariableName; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptCursorVariableRefExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlCursorVariableRefExpression))]
    internal sealed class SqlScriptCursorVariableRefExpression : SqlScriptCursorVariableRefExpression<SqlCursorVariableRefExpression>
        {
        #region ctor{IServiceProvider,SqlCursorVariableRefExpression}
        public SqlScriptCursorVariableRefExpression(IServiceProvider context,SqlCursorVariableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }