using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUserDefinedScalarFunctionCallExpression))]
    internal sealed class SqlScriptUserDefinedScalarFunctionCallExpression : SqlScriptScalarFunctionCallExpression<SqlUserDefinedScalarFunctionCallExpression>
        {
        #region ctor{IServiceProvider,SqlUserDefinedScalarFunctionCallExpression}
        public SqlScriptUserDefinedScalarFunctionCallExpression(IServiceProvider context,SqlUserDefinedScalarFunctionCallExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }