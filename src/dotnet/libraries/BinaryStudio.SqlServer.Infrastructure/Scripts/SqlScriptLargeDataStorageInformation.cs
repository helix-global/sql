using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptLargeDataStorageInformation : SqlScriptCodeObject<SqlLargeDataStorageInformation>
        {
        #region ctor{IServiceProvider,SqlLargeDataStorageInformation}
        public SqlScriptLargeDataStorageInformation(IServiceProvider context,SqlLargeDataStorageInformation source)
            : base(context,source)
            {
            }
        #endregion
        }
    }