using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CompressionDelayIndexOption))]
    internal sealed class SqlFragmentCompressionDelayIndexOption : SqlFragmentIndexOption<CompressionDelayIndexOption>
        {
        #region ctor{IServiceProvider,CompressionDelayIndexOption}
        public SqlFragmentCompressionDelayIndexOption(IServiceProvider context,CompressionDelayIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }