using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptScalarVariableRefExpression<T> : SqlScriptScalarExpression<T>
        where T : SqlScalarVariableRefExpression
        {
        public String VariableName { get { return Source.VariableName; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarVariableRefExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlScalarVariableRefExpression))]
    internal sealed class SqlScriptScalarVariableRefExpression : SqlScriptScalarVariableRefExpression<SqlScalarVariableRefExpression>
        {
        #region ctor{IServiceProvider,SqlScalarVariableRefExpression}
        public SqlScriptScalarVariableRefExpression(IServiceProvider context,SqlScalarVariableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }