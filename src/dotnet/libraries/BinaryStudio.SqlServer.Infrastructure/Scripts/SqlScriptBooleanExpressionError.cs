using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlBooleanExpressionError))]
    internal sealed class SqlScriptBooleanExpressionError : SqlScriptBooleanExpression<SqlBooleanExpressionError>
        {
        #region ctor{IServiceProvider,SqlBooleanExpressionError}
        public SqlScriptBooleanExpressionError(IServiceProvider context,SqlBooleanExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }