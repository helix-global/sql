using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptValuesInsertMergeActionSource : SqlScriptInsertMergeActionSource<SqlValuesInsertMergeActionSource>
        {
        #region ctor{IServiceProvider,SqlValuesInsertMergeActionSource}
        public SqlScriptValuesInsertMergeActionSource(IServiceProvider context,SqlValuesInsertMergeActionSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }