using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptScalarVariableAssignment : SqlScriptVariableAssignment<SqlScalarVariableAssignment>
        {
        #region ctor{IServiceProvider,SqlScalarVariableAssignment}
        public SqlScriptScalarVariableAssignment(IServiceProvider context,SqlScalarVariableAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }