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
    }