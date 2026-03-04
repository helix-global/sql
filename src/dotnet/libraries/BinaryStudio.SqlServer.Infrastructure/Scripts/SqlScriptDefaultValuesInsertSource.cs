using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDefaultValuesInsertSource : SqlScriptInsertSource<SqlDefaultValuesInsertSource>
        {
        #region ctor{IServiceProvider,SqlDefaultValuesInsertSource}
        public SqlScriptDefaultValuesInsertSource(IServiceProvider context,SqlDefaultValuesInsertSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }