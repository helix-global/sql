using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptJsonObjectArgument : SqlScriptCodeObject<SqlJsonObjectArgument>
        {
        #region ctor{IServiceProvider,SqlJsonObjectArgument}
        public SqlScriptJsonObjectArgument(IServiceProvider context,SqlJsonObjectArgument source)
            : base(context,source)
            {
            }
        #endregion
        }
    }