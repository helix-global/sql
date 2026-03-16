using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlValuesInsertMergeActionSource))]
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