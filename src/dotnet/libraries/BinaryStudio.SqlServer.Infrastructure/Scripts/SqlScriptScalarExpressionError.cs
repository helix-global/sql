using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlScalarExpressionError))]
    internal sealed class SqlScriptScalarExpressionError : SqlScriptScalarExpression<SqlScalarExpressionError>
        {
        #region ctor{IServiceProvider,SqlScalarExpressionError}
        public SqlScriptScalarExpressionError(IServiceProvider context,SqlScalarExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }