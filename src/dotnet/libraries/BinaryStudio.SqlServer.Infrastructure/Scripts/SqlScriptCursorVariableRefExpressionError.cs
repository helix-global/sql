using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCursorVariableRefExpressionError))]
    internal sealed class SqlScriptCursorVariableRefExpressionError : SqlScriptCursorVariableRefExpression<SqlCursorVariableRefExpressionError>
        {
        #region ctor{IServiceProvider,SqlCursorVariableRefExpressionError}
        public SqlScriptCursorVariableRefExpressionError(IServiceProvider context,SqlCursorVariableRefExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }