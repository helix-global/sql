using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBuiltinFunctionWithJsonNullQualifier : SqlScriptBuiltinScalarFunctionCallExpression<SqlBuiltinFunctionWithJsonNullQualifier>
        {
        #region ctor{IServiceProvider,SqlBuiltinFunctionWithJsonNullQualifier}
        public SqlScriptBuiltinFunctionWithJsonNullQualifier(IServiceProvider context,SqlBuiltinFunctionWithJsonNullQualifier source)
            : base(context,source)
            {
            }
        #endregion
        }
    }