using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlScalarVariableRefExpressionError))]
    internal sealed class SqlScriptScalarVariableRefExpressionError : SqlScriptScalarVariableRefExpression<SqlScalarVariableRefExpressionError>
        {
        #region ctor{IServiceProvider,SqlScalarVariableRefExpressionError}
        public SqlScriptScalarVariableRefExpressionError(IServiceProvider context,SqlScalarVariableRefExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }