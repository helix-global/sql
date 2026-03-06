using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlMaxDegreeOfParallelismIndexOption))]
    internal sealed class SqlScriptMaxDegreeOfParallelismIndexOption : SqlScriptIndexOption<SqlMaxDegreeOfParallelismIndexOption>
        {
        public Int32 DegreeOfParallelism {get{ return Source.DegreeOfParallelism; }}

        #region ctor{IServiceProvider,SqlMaxDegreeOfParallelismIndexOption}
        public SqlScriptMaxDegreeOfParallelismIndexOption(IServiceProvider context,SqlMaxDegreeOfParallelismIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }