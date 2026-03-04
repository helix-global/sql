using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using DataType=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlDataType;
    internal sealed class SqlScriptDataType : SqlScriptCodeObject<DataType>
        {
        #region ctor{IServiceProvider,SqlDataType}
        public SqlScriptDataType(IServiceProvider context,DataType source)
            : base(context, source)
            {
            }
        #endregion
        }
    }