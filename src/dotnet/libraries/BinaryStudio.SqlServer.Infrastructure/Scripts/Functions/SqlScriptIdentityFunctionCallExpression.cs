using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlIdentityFunctionCallExpression))]
    internal sealed class SqlScriptIdentityFunctionCallExpression : SqlScriptBuiltinScalarFunctionCallExpression<SqlIdentityFunctionCallExpression>
        {
        #region ctor{IServiceProvider,SqlIdentityFunctionCallExpression}
        public SqlScriptIdentityFunctionCallExpression(IServiceProvider context,SqlIdentityFunctionCallExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }