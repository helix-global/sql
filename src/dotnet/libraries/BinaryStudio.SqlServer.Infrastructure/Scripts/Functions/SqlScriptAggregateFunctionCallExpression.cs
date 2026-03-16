using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlAggregateFunctionCallExpression))]
    internal sealed class SqlScriptAggregateFunctionCallExpression : SqlScriptBuiltinScalarFunctionCallExpression<SqlAggregateFunctionCallExpression>
        {
        #region ctor{IServiceProvider,SqlAggregateFunctionCallExpression}
        public SqlScriptAggregateFunctionCallExpression(IServiceProvider context,SqlAggregateFunctionCallExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }