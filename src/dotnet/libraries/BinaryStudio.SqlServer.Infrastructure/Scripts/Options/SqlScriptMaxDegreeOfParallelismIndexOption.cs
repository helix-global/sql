using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlMaxDegreeOfParallelismIndexOption))]
    internal sealed class SqlScriptMaxDegreeOfParallelismIndexOption : SqlScriptIndexOption<SqlMaxDegreeOfParallelismIndexOption>
        {
        [UsedImplicitly][Field] public Int32 DegreeOfParallelism { get; }
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.MaxDegreeOfParallelism; }}

        #region ctor{IServiceProvider,SqlMaxDegreeOfParallelismIndexOption}
        public SqlScriptMaxDegreeOfParallelismIndexOption(IServiceProvider context,SqlMaxDegreeOfParallelismIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }