using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTableExpressionError))]
    internal sealed class SqlScriptTableExpressionError : SqlScriptTableExpression<SqlTableExpressionError>
        {
        #region ctor{IServiceProvider,SqlTableExpressionError}
        public SqlScriptTableExpressionError(IServiceProvider context,SqlTableExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }