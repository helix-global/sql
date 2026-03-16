using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlScalarFunctionReturnType))]
    internal sealed class SqlScriptScalarFunctionReturnType : SqlScriptFunctionReturnType<SqlScalarFunctionReturnType>
        {
        #region ctor{IServiceProvider,SqlScalarFunctionReturnType}
        public SqlScriptScalarFunctionReturnType(IServiceProvider context,SqlScalarFunctionReturnType source)
            : base(context,source)
            {
            }
        #endregion
        }
    }