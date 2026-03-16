using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDefaultValuesInsertMergeActionSource))]
    internal sealed class SqlScriptDefaultValuesInsertMergeActionSource : SqlScriptInsertMergeActionSource<SqlDefaultValuesInsertMergeActionSource>
        {
        #region ctor{IServiceProvider,SqlDefaultValuesInsertMergeActionSource}
        public SqlScriptDefaultValuesInsertMergeActionSource(IServiceProvider context,SqlDefaultValuesInsertMergeActionSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }